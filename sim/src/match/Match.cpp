// footballhome sim - Match implementation
//
// See Match.hpp. This file wires the tick loop; the actual gameplay math
// lives in Mechanics.cpp, and physics integration lives in StubPhysics.

#include "match/Match.hpp"

#include "common/M0Attributes.hpp"
#include "controller/HumanController.hpp"
#include "controller/WanderController.hpp"
#include "physics/BallPhysics.hpp"

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

    // -----------------------------------------------------------------
    // Ball spawn (Slice 15.2).
    //
    // Ball is a physics entity with is_ball=true and slot_id=0 (§7.2:
    // slot 0 is reserved for the ball). No controller, no mechanics —
    // its velocity decays each tick via BallPhysics::tickBall(), and
    // physics.step() integrates position from that velocity like any
    // other entity. Absent-ball scenarios (M0 EmptyPitchScenario) return
    // nullopt here, so ball_ stays nullopt and the tick loop skips the
    // ball branch entirely.
    // -----------------------------------------------------------------
    if (const auto bs = scenario_->ballSpawn(); bs.has_value()) {
        physics::EntityDef bdef;
        bdef.slot_id  = SlotId{0};
        bdef.position = bs->position;
        bdef.velocity = bs->velocity;
        bdef.radius   = math::Fixed64::zero();   // M1: no collisions yet
        bdef.height   = math::Fixed64::zero();
        bdef.is_ball  = true;

        const EntityId eid = physics_->spawn(bdef);
        physics_->setHeading(eid, math::Fixed64::zero());
        physics_->setMotion (eid, MotionState::Idle);
        ball_ = eid;
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
    // Ball friction pass (Slice 15.2).
    //
    // Applies passive multiplicative decay to the ball's velocity, then
    // lets physics.step() below integrate position from that decayed
    // velocity. Runs after the per-slot mechanics loop so a future
    // Slice 16 kick mechanic can setVelocity() on the ball first and
    // still get its friction applied this same tick (kick → decay →
    // integrate — kick propagates immediately, one-tick lag on decay).
    // -----------------------------------------------------------------
    if (ball_.has_value()) {
        EntityState ball = physics_->get(*ball_);
        physics::tickBall(ball,
                          physics::kDefaultBallDecayPerTick,
                          physics::kDefaultBallRestThreshold);
        physics_->setVelocity(*ball_, ball.velocity);
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

void Match::claimSlot(SlotId slot_id,
                      ClientId client,
                      PersonId person,
                      profile::PlayerProfile profile)
{
    // Locate the slot's index in the sorted vector so we can also refresh
    // the parallel params_by_slot_ array. Linear scan is fine — this runs
    // at most once per client-connect, not per tick.
    std::size_t idx = 0;
    for (; idx < slots_.size(); ++idx) {
        if (slots_[idx].slot_id == slot_id) { break; }
    }
    if (idx == slots_.size()) { return; }

    Slot& s = slots_[idx];

    // Idempotent: repeated claim by the same client is a no-op. The first
    // claim's profile wins for the session — profile refreshes require
    // an explicit release+claim cycle.
    if (s.owner.has_value() && *s.owner == client) {
        return;
    }

    s.controller = std::make_unique<controller::HumanController>(client);
    s.owner      = client;
    s.person     = person;
    s.profile    = std::move(profile);

    // Attribute values drive movement caps + stamina curve. Refreshing
    // params here is the whole point of per-person profiles (§16.6).
    params_by_slot_[idx] = MechanicsParams::fromPhysical(s.profile.physical);
}

void Match::releaseSlot(SlotId slot_id)
{
    std::size_t idx = 0;
    for (; idx < slots_.size(); ++idx) {
        if (slots_[idx].slot_id == slot_id) { break; }
    }
    if (idx == slots_.size()) { return; }

    Slot& s = slots_[idx];

    const scenario::PitchSpec pitch = scenario_->pitch();
    s.controller = std::make_unique<controller::WanderController>(
        pitch.length_m, pitch.width_m, &rng_);
    s.owner.reset();
    s.person.reset();

    // Wander AI runs on the M0 baseline profile — a released slot has no
    // "identity" any more. Values live in M0Attributes.cpp (§22.11).
    s.profile.physical = m0::defaultPhysical();
    s.profile.concepts = m0::defaultConcepts();
    // technical, mental, recognition stay empty (M0).

    params_by_slot_[idx] = MechanicsParams::fromPhysical(s.profile.physical);
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

    snap.entities.reserve(slots_.size() + (ball_.has_value() ? 1u : 0u));

    // Ball first — SlotId{0} sorts ahead of every player slot (1..N),
    // so this keeps the "sorted by slot_id ascending" invariant §5.7
    // documents on Snapshot without a post-hoc sort pass.
    if (ball_.has_value()) {
        SnapshotEntity be;
        be.state              = physics_->get(*ball_);
        be.flags.human_controlled = false;
        be.flags.is_ball          = true;
        be.flags.active           = true;
        snap.entities.push_back(be);
    }

    for (const Slot& slot : slots_) {
        SnapshotEntity se;
        se.state              = physics_->get(slot.entity);
        se.flags.human_controlled = slot.owner.has_value();
        se.flags.is_ball          = false;
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
