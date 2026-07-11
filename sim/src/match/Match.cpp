// footballhome sim - Match implementation
//
// See Match.hpp. This file wires the tick loop; the actual gameplay math
// lives in Mechanics.cpp, and physics integration lives in StubPhysics.

#include "match/Match.hpp"

#include "common/M0Attributes.hpp"
#include "controller/HumanController.hpp"
#include "controller/WanderController.hpp"

#include <algorithm>
#include <cstdint>
#include <utility>

namespace fh::sim::match {

Match::Match(MatchConfig cfg)
    : id_(cfg.id)
    , seed_(cfg.seed)
    , server_version_(std::move(cfg.server_version))
    , physics_(std::move(cfg.physics))
    , scenario_(std::move(cfg.scenario))
    , clock_(std::move(cfg.clock))
    , recognition_{}
    , rng_(cfg.seed)
{
    spawnInitialSlots();
}

void Match::spawnInitialSlots()
{
    const scenario::PitchSpec pitch    = scenario_->pitch();
    const auto                spawns   = scenario_->initialSpawns();

    slots_.reserve(spawns.size());
    params_by_slot_.reserve(spawns.size());

    for (const auto& s : spawns) {
        physics::EntityDef def;
        def.slot_id  = s.slot;
        def.position = s.position;
        def.velocity = math::Vec3{};   // zero
        def.radius   = math::Fixed64::zero();   // M0: no collisions
        def.height   = math::Fixed64::zero();
        def.is_ball  = false;

        const EntityId eid = physics_->spawn(def);
        physics_->setHeading(eid, s.heading);
        physics_->setMotion(eid, MotionState::Idle);

        Slot slot;
        slot.slot_id = s.slot;
        slot.entity  = eid;
        slot.owner   = std::nullopt;
        slot.role    = s.role;
        slot.profile.physical = m0::defaultPhysical();
        slot.profile.concepts = m0::defaultConcepts();
        // technical, mental, recognition stay empty (M0)

        // Default controller: WanderController for unclaimed slots.
        slot.controller = std::make_unique<controller::WanderController>(
            pitch.length_m, pitch.width_m, &rng_);
        slot.stamina    = math::Fixed64::one();

        params_by_slot_.push_back(MechanicsParams::fromPhysical(slot.profile.physical));
        slots_.push_back(std::move(slot));
    }

    // Sort by SlotId so snapshot() output and iteration order are stable
    // regardless of what order scenario->initialSpawns() returned them in.
    // We must also reorder params_by_slot_ in lockstep.
    if (!std::is_sorted(slots_.begin(), slots_.end(),
                        [](const Slot& a, const Slot& b) {
                            return a.slot_id < b.slot_id;
                        })) {
        // Build a pairing then re-emit sorted.
        std::vector<std::pair<Slot, MechanicsParams>> paired;
        paired.reserve(slots_.size());
        for (std::size_t i = 0; i < slots_.size(); ++i) {
            paired.emplace_back(std::move(slots_[i]), params_by_slot_[i]);
        }
        std::sort(paired.begin(), paired.end(),
                  [](const auto& a, const auto& b) {
                      return a.first.slot_id < b.first.slot_id;
                  });
        slots_.clear();
        params_by_slot_.clear();
        for (auto& [s, p] : paired) {
            slots_.push_back(std::move(s));
            params_by_slot_.push_back(p);
        }
    }
}

awareness::WorldView Match::buildWorldView() const
{
    awareness::WorldView w;
    w.tick         = clock_->current();
    w.time_seconds = clock_->elapsedSeconds();
    w.ball         = ball_;   // nullopt in M0

    const auto ids = physics_->all();   // sorted ascending
    w.entities.reserve(ids.size());
    for (const EntityId id : ids) {
        w.entities.push_back(physics_->get(id));
    }
    return w;
}

void Match::tick()
{
    if (ended_) { return; }

    const math::Fixed64 dt = clock_->dt();

    // -----------------------------------------------------------------
    // Recognition + Decision + Execution, per slot.
    // Physics is stepped ONCE after all slots have written their velocity /
    // heading / motion. This means all slots decide from the same WorldView
    // — no first-mover advantage inside a tick.
    // -----------------------------------------------------------------
    const awareness::WorldView world = buildWorldView();

    for (std::size_t i = 0; i < slots_.size(); ++i) {
        Slot&                     slot = slots_[i];
        const MechanicsParams&    mech = params_by_slot_[i];

        const awareness::AwarenessView av =
            recognition_.apply(world, slot.profile, slot.slot_id);
        const controller::Intent intent =
            slot.controller->decide(av, slot.slot_id);

        const EntityState current = physics_->get(slot.entity);
        const MechanicsResult res  =
            applyIntent(intent, current, slot.stamina, mech, dt);

        physics_->setVelocity(slot.entity, res.new_velocity);
        physics_->setHeading (slot.entity, res.new_heading);
        physics_->setMotion  (slot.entity, res.new_motion);
        slot.stamina = res.new_stamina;
    }

    // -----------------------------------------------------------------
    // Integrate positions.
    // -----------------------------------------------------------------
    physics_->step(dt);

    // -----------------------------------------------------------------
    // Scenario checks — M0 EmptyPitchScenario returns false for both,
    // so this is effectively a no-op until later milestones.
    // -----------------------------------------------------------------
    const awareness::WorldView post = buildWorldView();
    if (scenario_->checkSuccess(post) || scenario_->checkReset(post)) {
        // Reserved for M3+ scenario transitions. M0 never enters here.
    }

    clock_->advance();
}

void Match::claimSlot(SlotId slot_id, ClientId client)
{
    Slot* s = findSlot(slot_id);
    if (s == nullptr) { return; }

    if (s->owner.has_value() && *s->owner == client) {
        return;   // idempotent
    }

    s->controller = std::make_unique<controller::HumanController>(client);
    s->owner      = client;
}

void Match::releaseSlot(SlotId slot_id)
{
    Slot* s = findSlot(slot_id);
    if (s == nullptr) { return; }

    const scenario::PitchSpec pitch = scenario_->pitch();
    s->controller = std::make_unique<controller::WanderController>(
        pitch.length_m, pitch.width_m, &rng_);
    s->owner.reset();
}

void Match::applyInput(ClientId client, const controller::Intent& intent)
{
    Slot* s = findSlotByOwner(client);
    if (s == nullptr) { return; }

    // Only HumanController accepts input. dynamic_cast is fine here — this
    // is a rare path (once per input message, not per tick per slot).
    auto* hc = dynamic_cast<controller::HumanController*>(s->controller.get());
    if (hc != nullptr) {
        hc->updateInput(intent);
    }
}

TickNum Match::tick_num() const noexcept
{
    return clock_->current();
}

math::Fixed64 Match::elapsedSeconds() const noexcept
{
    return clock_->elapsedSeconds();
}

Snapshot Match::snapshot() const
{
    Snapshot snap;
    snap.tick = clock_->current();

    // match_time_ms = elapsedSeconds * 1000, truncated to u32.
    // Convert via Fixed64 * 1000 → int, clamp to u32 max.
    const math::Fixed64 ms_fx =
        clock_->elapsedSeconds() * math::Fixed64::fromInt(1000);
    // Raw integer part of Fixed64 = raw >> FRAC_BITS.
    const std::int64_t ms_i64 =
        ms_fx.raw >> math::Fixed64::FRAC_BITS;
    const std::uint32_t ms_u32 =
        (ms_i64 < 0)                             ? 0u :
        (ms_i64 > 0xFFFFFFFFLL)                  ? 0xFFFFFFFFu :
        static_cast<std::uint32_t>(ms_i64);
    snap.match_time_ms = ms_u32;

    snap.entities.reserve(slots_.size());
    for (const Slot& slot : slots_) {
        SnapshotEntity se;
        se.state              = physics_->get(slot.entity);
        se.flags.human_controlled = slot.owner.has_value();
        se.flags.is_ball          = false;   // no ball in M0
        se.flags.active           = true;
        snap.entities.push_back(se);
    }
    return snap;
}

Slot* Match::findSlot(SlotId slot_id) noexcept
{
    for (Slot& s : slots_) {
        if (s.slot_id == slot_id) { return &s; }
    }
    return nullptr;
}

const Slot* Match::findSlot(SlotId slot_id) const noexcept
{
    for (const Slot& s : slots_) {
        if (s.slot_id == slot_id) { return &s; }
    }
    return nullptr;
}

Slot* Match::findSlotByOwner(ClientId client) noexcept
{
    for (Slot& s : slots_) {
        if (s.owner.has_value() && *s.owner == client) { return &s; }
    }
    return nullptr;
}

} // namespace fh::sim::match
