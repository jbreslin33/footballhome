// footballhome sim - Match implementation
//
// See Match.hpp. This file wires the tick loop; the actual gameplay math
// lives in Mechanics.cpp, and physics integration lives in StubPhysics.

#include "match/Match.hpp"

#include "common/M0Attributes.hpp"
#include "controller/AiController.hpp"
#include "controller/HumanController.hpp"
#include "controller/IdleController.hpp"
#include "controller/WanderController.hpp"
#include "mechanics/BallControl.hpp"
#include "physics/BallPhysics.hpp"
#include "physics/PlayableAreaConstraint.hpp"

#include <algorithm>
#include <cstdint>
#include <utility>

namespace fh::sim::match {

namespace {

// Slice 17.3: default spring stiffness (1/s) for Soft-mode playable-area
// scenarios. No scenario shipped in Slice 17.3 uses Soft mode yet — the
// first will land in Slice 17.5 (SoftDrillScenario). At that point this
// value may either stay as-is (a single global default) or migrate to a
// per-scenario field on `scenario::PlayableArea`, depending on whether
// M2 introduces multiple distinct soft-mode drills. Chosen so a 1 m
// penetration produces a 4 m/s inward velocity delta — bounces the
// player back inside within ~0.25 s at the M1 tick rate (20 Hz).
inline math::Fixed64 defaultSoftStiffness() noexcept
{
    return math::Fixed64::fromInt(4);
}

} // namespace

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

    // Slice 17.3: cache the playable-area constraint once. Scenarios are
    // required to be declarative (§5.6) — playableArea() returns the same
    // value every call — so we only need to fetch it here at match setup.
    playable_area_ = scenario_->playableArea();

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
        // Slice 24.3b: scenario hook to override specific physical
        // attributes on top of defaults (e.g. weaker dribble for a
        // demo defender). No-op for scenarios that don't override.
        scenario_->applyPhysicalOverrides(s.slot, slot.profile.physical);
        // Slice 30.2: symmetric hook for per-slot concept overrides
        // (e.g. plug `pressing` for a defender slot so its
        // PursueBallCarrierBehavior's gate opens). No-op for scenarios
        // that don't override — 11 pre-M3 goldens stay byte-identical.
        scenario_->applyConceptOverrides(s.slot, slot.profile.concepts);
        // technical, mental, recognition stay empty (M0)

        // Slice 27.2 (ADR §22.24): seed the physics world's per-entity
        // body_mass from the freshly-populated (defaults + scenario
        // overrides) physical profile. Without this, BasicPhysics would
        // fall back to kBodyMassDefault=1.0 for every unclaimed slot on
        // tick 1 — correct value but wrong contract: physics should not
        // second-guess the profile. Clamp to [0.5, 1.5] happens inside
        // BasicPhysics::clampedBodyMass on READ, so mis-authored
        // overrides can't destabilise the resolver. StubPhysics no-ops
        // this call so pre-M2 tests are unaffected.
        physics_->setBodyMass(
            eid,
            slot.profile.physical.get(m0::kBodyMass, math::Fixed64::one()));

        // Default controller for unclaimed slots. Scenario decides
        // per-slot via unclaimedControllerFor():
        //   Wander   -> WanderController (consumes RNG; M0/M1 goldens
        //               locked to this stream).
        //   Idle     -> IdleController   (zero RNG; solo-play default
        //               so a lone joystick user is not fought by an
        //               AI; Slice 24.2).
        //   Defender -> AiController with defaultBehaviors(Role::Any)
        //               = {PursueBallCarrierBehavior} (zero RNG; jogs
        //               toward the ball; Slice 24.3a semantics
        //               replicated at IBehavior::execute() level in
        //               Slice 30.2, gated by the `pressing` concept
        //               plugged via applyConceptOverrides above).
        // See Scenario::unclaimedControllerFor() for the enum contract.
        switch (scenario_->unclaimedControllerFor(s.slot)) {
            case scenario::UnclaimedControllerKind::Idle:
                slot.controller = std::make_unique<controller::IdleController>();
                break;
            case scenario::UnclaimedControllerKind::Defender:
                // Slice 30.2: swap DefenderController → AiController
                // with the pursue bag. slot.profile.concepts is copied
                // in (AiController owns its own ConceptSet copy) — the
                // `pressing` concept was plugged just above by
                // applyConceptOverrides so PursueBallCarrierBehavior's
                // presence-gate opens on the very first decide() call.
                slot.controller = std::make_unique<controller::AiController>(
                    Role::Any,
                    slot.profile.concepts,
                    controller::AiController::defaultBehaviors(Role::Any));
                break;
            case scenario::UnclaimedControllerKind::Wander:
            default:
                slot.controller = std::make_unique<controller::WanderController>(
                    pitch.length_m, pitch.width_m, &rng_);
                break;
        }
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
        // Slice 27.2 (ADR §22.24): the ball is excluded from the
        // BasicPhysics collision pass entirely (see BasicPhysics.hpp
        // header comment for the kBallControlRadius rationale), so its
        // body_mass is never READ during a collision resolution.
        // We still seed the default so a diagnostic dump of every
        // entity's mass is complete and so a future M4+ change that
        // includes the ball in some collision context has a sane
        // starting value.
        physics_->setBodyMass(eid, math::Fixed64::one());
        ball_ = eid;
    }
}

awareness::WorldView Match::buildWorldView() const
{
    awareness::WorldView w;
    w.tick         = clock_->current();
    w.time_seconds = clock_->elapsedSeconds();
    w.ball         = ball_;   // nullopt in M0
    // Slice 24.3b: expose current owner so AI controllers can check
    // "am I the owner" without proxy-inference from geometry. This is
    // last-tick's owner as decided by BallControl; on the very first
    // tick it's nullopt (Match::ball_owner_ is default-constructed).
    w.ball_owner   = ball_owner_;

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

    // Slice 16.3: harvest per-slot Intent + post-mechanics velocity/heading
    // for the BallControl pass below. Only populated when a ball exists —
    // ball-less scenarios (EmptyPitchScenario) skip the alloc entirely,
    // preserving the M0 canonical hash by leaving the tick loop's
    // observable shape identical for them.
    std::vector<mechanics::BallControlSlot> bc_slots;
    if (ball_.has_value()) {
        bc_slots.reserve(slots_.size());
    }

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

        if (ball_.has_value()) {
            mechanics::BallControlSlot bcs;
            bcs.slot_id            = slot.slot_id;
            bcs.position           = current.position;
            bcs.new_velocity       = res.new_velocity;
            bcs.heading            = res.new_heading;
            bcs.wants_dribble      = intent.wants_dribble;
            // Slice 25.2: pipe sprint intent through so BallControl can
            // pick max_carry_sprint_speed vs max_dribble_speed for the
            // owner's velocity cap.
            bcs.wants_sprint       = intent.wants_sprint;
            // Slice 24.3b: pipe the press bit + press_resistance rating
            // through so BallControl can run the contest step.
            bcs.wants_to_press     = intent.wants_to_press;
            bcs.press_resistance   = mech.press_resistance;
            bcs.dribble_efficiency = mech.dribble_efficiency;
            // Slice 26.3 (ADR §22.23): pipe the wire kick trailer
            // through so BallControl can release-on-kick this tick.
            // BallControl ignores these unless THIS slot is the
            // current owner AND would otherwise retain via Rule 2,
            // so the eight bytes here have no observable effect on
            // any pre-Slice-26.3 golden.
            bcs.wants_kick         = intent.wants_kick;
            bcs.kick_direction     = intent.kick_direction;
            bcs.kick_power_hint    = intent.kick_power_hint;
            bcs.pass_power         = mech.pass_power;
            bcs.params             = &mech;
            bc_slots.push_back(bcs);
        }
    }

    // -----------------------------------------------------------------
    // Ball control pass (Slice 16.3).
    //
    // Runs BETWEEN the per-slot mechanics loop and the ball friction
    // pass so an owned ball can (a) override the owner's velocity to
    // the dribble-capped magnitude, (b) glue the ball's position + vel
    // to the owner's for coherent physics.step integration, and (c)
    // suppress friction (a rolling ball obeys friction; a dribbled
    // ball moves with the player).
    //
    // Rules live in mechanics/BallControl.hpp. This code just wires
    // the mechanic's result back into physics.
    // -----------------------------------------------------------------
    bool ball_is_owned = false;
    if (ball_.has_value()) {
        const EntityState ball_state = physics_->get(*ball_);
        const auto bc = mechanics::resolveBallControl(
            ball_owner_, ball_state.position,
            bc_slots.data(), bc_slots.size());

        // Slice 28.3: snapshot the pre-tick owner BEFORE the reassignment
        // below overwrites it. Used only in the `bc.kicked` branch to
        // attribute a subsequent goal to whichever slot's Intent
        // asserted `wants_kick` this tick (BallControl requires the
        // kicker to be the current owner, so pre-tick owner == kicker).
        const std::optional<SlotId> prev_owner = ball_owner_;

        ball_owner_ = bc.owner;
        if (bc.owner.has_value()) {
            ball_is_owned = true;
            // Overwrite the owner slot's velocity with the dribble-capped
            // magnitude. Linear scan is fine — slots_ is small and this
            // runs at most once per tick.
            for (const Slot& s : slots_) {
                if (s.slot_id == *bc.owner) {
                    physics_->setVelocity(s.entity, bc.owner_capped_velocity);
                    break;
                }
            }
            // Teleport ball to the glue point PRE-step, then set its
            // velocity equal to the owner's capped velocity. physics.step
            // integrates both by the same delta, so post-step the ball is
            // at owner.new_position + kBallOwnerLeadDistance*(cos h, sin h).
            physics_->setPosition(*ball_, bc.ball_target_position);
            physics_->setVelocity(*ball_, bc.ball_target_velocity);
        } else if (bc.kicked) {
            // Slice 26.3 (ADR §22.23): release-on-kick. The previous
            // owner asserted Intent::wants_kick this tick; ownership
            // has already been dropped by resolveBallControl (bc.owner
            // == nullopt above). Apply the kick impulse to the ball
            // BEFORE physics.step so the kicked velocity gets
            // integrated into a position delta this same tick, and
            // arm the kick-alive counter so tickBall skips its
            // snap-to-rest clamp for the pass runway (see
            // physics::kKickAliveTicks).
            EntityState ball = physics_->get(*ball_);
            physics::applyImpulse(ball, bc.kick_direction, bc.kick_speed);
            physics_->setVelocity(*ball_, ball.velocity);
            kick_alive_ticks_remaining_ = physics::kKickAliveTicks;

            // Slice 28.3: remember who last kicked so a subsequent
            // ball-crosses-goal-AABB detection can attribute the goal.
            // `prev_owner` is guaranteed to have a value here because
            // BallControl only produces `kicked=true` from an owned
            // ball. Overwrites any earlier last_kicker_slot_ — the
            // most recent kick wins for attribution.
            last_kicker_slot_ = prev_owner;
        }
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
    //
    // Slice 16.3: SKIPPED when the ball has an owner. A dribbled ball
    // is dictated by the owner's motion, not by passive rolling.
    // -----------------------------------------------------------------
    if (ball_.has_value() && !ball_is_owned) {
        EntityState ball = physics_->get(*ball_);
        // Slice 26.3 (ADR §22.23): skip tickBall's snap-to-rest clamp
        // for kKickAliveTicks ticks after a kick so a slow pass isn't
        // killed by the friction floor before it can reach a receiver.
        // kick_alive_ticks_remaining_ was armed to kKickAliveTicks by
        // the wants_kick branch above (or, when the kick fired on a
        // previous tick, decremented from that armed value below).
        // Zero for every tick of every pre-Slice-26.3 golden — the
        // false-branch is byte-identical to the M1 behaviour.
        const bool skip_rest_snap = kick_alive_ticks_remaining_ > 0;
        physics::tickBall(ball,
                          physics::kDefaultBallDecayPerTick,
                          physics::kDefaultBallRestThreshold,
                          skip_rest_snap);
        physics_->setVelocity(*ball_, ball.velocity);
    }

    // Slice 26.3: decrement the kick-alive counter each tick, saturating
    // at zero. Placed AFTER the friction pass so the tick that armed the
    // counter still exercised the skip. When the ball is owned again
    // mid-pass (someone else picked it up) the counter still counts down
    // — that's fine, it will simply be zero by the time the next kick
    // fires unless a rapid re-kick happens.
    if (kick_alive_ticks_remaining_ > 0) {
        --kick_alive_ticks_remaining_;
    }

    // -----------------------------------------------------------------
    // Playable-area Soft pass (Slice 17.3).
    //
    // Soft mode applies an inward-facing velocity delta BEFORE
    // integration so the next physics.step() naturally advects the
    // player back toward the polygon. Advisory mode (M0/M1 baseline)
    // and empty polygons are both no-ops — the mode check gates the
    // entire loop so the canonical hash for baseline scenarios is
    // preserved byte-identically.
    //
    // Applied to slots only. The ball is intentionally excluded from
    // constraint passes for now: ball out-of-play handling (goals,
    // throw-ins, corners) is a scenario-level event landing later,
    // not a boundary clamp — see DESIGN.md §2.4.
    //
    // TODO(M1 §5.6): soft-mode stiffness `k` will move from the
    // per-tick hard-coded default (kDefaultSoftStiffness) to a
    // scenario- or profile-provided parameter once the first drill
    // scenario surfaces it. For now every soft-mode scenario shares
    // this default.
    // -----------------------------------------------------------------
    if (playable_area_.constraint_mode == scenario::PlayableArea::Mode::Soft
        && !playable_area_.polygon.empty())
    {
        for (const Slot& s : slots_) {
            EntityState st = physics_->get(s.entity);
            physics::apply_soft(st.position, st.velocity,
                                playable_area_.polygon,
                                defaultSoftStiffness());
            physics_->setVelocity(s.entity, st.velocity);
        }
    }

    // -----------------------------------------------------------------
    // Integrate positions.
    // -----------------------------------------------------------------
    physics_->step(dt);

    // -----------------------------------------------------------------
    // Playable-area Hard pass (Slice 17.3).
    //
    // Hard mode runs AFTER integration so any position that escaped
    // the polygon this step is snapped back and its outward velocity
    // is zeroed. Same Advisory-is-no-op guarantee as the Soft pass.
    // -----------------------------------------------------------------
    if (playable_area_.constraint_mode == scenario::PlayableArea::Mode::Hard
        && !playable_area_.polygon.empty())
    {
        for (const Slot& s : slots_) {
            EntityState st = physics_->get(s.entity);
            physics::apply_hard(st.position, st.velocity,
                                playable_area_.polygon);
            physics_->setPosition(s.entity, st.position);
            physics_->setVelocity(s.entity, st.velocity);
        }
    }

    // -----------------------------------------------------------------
    // Slice 28.3: post-physics goal detection (ADR §22.25).
    //
    // Rule: after positions are integrated (and Hard-mode clamped), if
    // the ball is inside any GoalRegion AABB returned by the scenario,
    // and it was NOT inside that same region on the previous tick, we
    // emit exactly one PendingGoal row. AABB inclusion is inclusive on
    // both ends (min/max are documented as `min <= max` and the
    // predicate uses `>=` / `<=` on all three axes).
    //
    // Edge-triggering:
    //   * Prev nullopt, curr set        → NEW GOAL (emit).
    //   * Prev set,     curr different  → NEW GOAL (emit). Ball crossed
    //                                     from one region to another
    //                                     without any tick outside —
    //                                     physically impossible for
    //                                     GoalDrillScenario (regions
    //                                     are 105 m apart) but the
    //                                     predicate covers it for M3+
    //                                     drills with adjacent AABBs.
    //   * Prev == curr                  → no-op. Ball is still sitting
    //                                     inside; we already emitted.
    //   * Prev set, curr nullopt        → no-op. Ball left the region
    //                                     without a fresh entry; the
    //                                     next entry re-arms detection.
    //
    // Freeze rule: on emit, zero the ball's velocity so it stops on
    // the spot. The 28.4/28.5 slices (wire + goldens) rely on the ball
    // NOT bouncing back out — the sim never emits two goals for one
    // physical entry, which matches every real sport's ref-blows-the-
    // whistle semantics. Also reset kick_alive_ticks_remaining_ so the
    // next tick's friction pass runs the normal rest-snap clamp,
    // and clear last_kicker_slot_ so a subsequent goal without a
    // kick fired between (i.e., dribbled in) is not misattributed.
    //
    // Grandfather clause: `regions.empty()` returns immediately, so
    // every pre-28 scenario (EmptyPitchScenario, BallOnPitchScenario,
    // HalfPitchScenario, SoftDrillScenario, BallOnPitchWithDefender,
    // BallOnPitch2v0Scenario) is byte-identical to its Slice-27
    // canonical hash. Only GoalDrillScenario (scenario_id=6) advertises
    // regions in M2.
    // -----------------------------------------------------------------
    std::optional<std::uint8_t> curr_ball_goal_region_index;
    if (ball_.has_value()) {
        const auto regions = scenario_->goalRegions();
        if (!regions.empty()) {
            const math::Vec3 ball_pos = physics_->get(*ball_).position;
            for (const auto& r : regions) {
                if (ball_pos.x >= r.min.x && ball_pos.x <= r.max.x &&
                    ball_pos.y >= r.min.y && ball_pos.y <= r.max.y &&
                    ball_pos.z >= r.min.z && ball_pos.z <= r.max.z)
                {
                    curr_ball_goal_region_index = r.index;
                    break;   // first-match wins; region overlaps are
                             // scenario-authoring bugs, not runtime cases
                }
            }

            if (curr_ball_goal_region_index.has_value()
                && curr_ball_goal_region_index != prev_ball_goal_region_index_)
            {
                PendingGoal pg;
                // clock_->current() has NOT been advanced yet (that
                // happens at the tail of tick() below). We record the
                // POST-advance tick number so the emitted event lines
                // up with the tick_num of the snapshot SimServer
                // broadcasts immediately after this tick returns
                // (Snapshot::tick == clock_->current() read AFTER
                // advance). Concretely: goal fires during the Nth call
                // to tick() → PendingGoal::tick_num == N == snapshot.tick.
                pg.tick_num          = clock_->current() + fh::sim::TickNum{1};
                pg.goal_region_index = *curr_ball_goal_region_index;
                pg.kicker_slot       = last_kicker_slot_;
                pending_goals_.push_back(pg);

                // Freeze the ball on the spot.
                physics_->setVelocity(*ball_, math::Vec3{});
                kick_alive_ticks_remaining_ = 0;

                // Clear kicker attribution so the next goal (if any)
                // requires a fresh kick to be attributed.
                last_kicker_slot_.reset();
            }
        }
    }
    prev_ball_goal_region_index_ = curr_ball_goal_region_index;

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

    // Slice 27.2 (ADR §22.24): refresh the physics world's cached
    // body_mass from the claim's profile so BasicPhysics's MTV split
    // uses the claimant's real physical.body_mass value (default 1.0
    // per migration 220) on the very next tick. StubPhysics no-ops.
    physics_->setBodyMass(
        s.entity,
        s.profile.physical.get(m0::kBodyMass, math::Fixed64::one()));
}

void Match::releaseSlot(SlotId slot_id)
{
    std::size_t idx = 0;
    for (; idx < slots_.size(); ++idx) {
        if (slots_[idx].slot_id == slot_id) { break; }
    }
    if (idx == slots_.size()) { return; }

    Slot& s = slots_[idx];

    s.owner.reset();
    s.person.reset();

    // Wander/idle AI runs on the M0 baseline profile — a released slot
    // has no "identity" any more. Values live in M0Attributes.cpp (§22.11).
    //
    // Slice 30.2: profile reset moved above the controller-policy
    // switch so the AiController constructed for Defender-kind slots
    // sees the freshly-reset + overlaid ConceptSet (with `pressing`
    // re-plugged by applyConceptOverrides) and its behavior gates
    // open on the very first post-release tick.
    s.profile.physical = m0::defaultPhysical();
    s.profile.concepts = m0::defaultConcepts();
    // Slice 24.3b: re-apply per-slot scenario attribute overrides so
    // a reclaimed-to-unclaimed slot ends up in the SAME attribute
    // state it had at initial spawn. Symmetric with spawnInitialSlots.
    scenario_->applyPhysicalOverrides(s.slot_id, s.profile.physical);
    // Slice 30.2: symmetric re-apply for ConceptSet overrides so a
    // released defender slot re-picks-up the `pressing` concept its
    // AiController needs when it re-spawns.
    scenario_->applyConceptOverrides(s.slot_id, s.profile.concepts);
    // technical, mental, recognition stay empty (M0).

    // Slice 24.2 / 24.3a: mirror spawnInitialSlots' controller-policy
    // dispatch so a slot released mid-match reverts to the same kind of
    // AI it was originally spawned with — otherwise a solo BallOnPitch
    // user who disconnects and reconnects would suddenly find a
    // wandering AI in the seat they just vacated, and a BallOnPitch +
    // Defender user releasing slot 2 would lose the defender.
    const scenario::PitchSpec pitch = scenario_->pitch();
    switch (scenario_->unclaimedControllerFor(s.slot_id)) {
        case scenario::UnclaimedControllerKind::Idle:
            s.controller = std::make_unique<controller::IdleController>();
            break;
        case scenario::UnclaimedControllerKind::Defender:
            // Slice 30.2: Defender-kind now dispatches to AiController
            // with the pursue bag instead of the deleted
            // DefenderController. Slot's ConceptSet is copied in
            // (AiController owns its own copy).
            s.controller = std::make_unique<controller::AiController>(
                Role::Any,
                s.profile.concepts,
                controller::AiController::defaultBehaviors(Role::Any));
            break;
        case scenario::UnclaimedControllerKind::Wander:
        default:
            s.controller = std::make_unique<controller::WanderController>(
                pitch.length_m, pitch.width_m, &rng_);
            break;
    }

    params_by_slot_[idx] = MechanicsParams::fromPhysical(s.profile.physical);

    // Slice 27.2 (ADR §22.24): symmetric with the claim path — reset
    // the physics world's cached body_mass to the released slot's
    // (defaults + overrides) profile value so BasicPhysics resumes
    // MTV-splitting against the spawn-time mass on the next tick.
    physics_->setBodyMass(
        s.entity,
        s.profile.physical.get(m0::kBodyMass, math::Fixed64::one()));
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

void Match::end() noexcept
{
    // Idempotent — repeated calls just re-clear ownership.
    ended_       = true;
    // Slice 16.4: match-end is one of the three release conditions
    // (§23.3 Slice 16.4). Clearing here means a snapshot taken after
    // end() shows the ball as loose on the wire, and a hypothetical
    // post-end resume (M2+) would start with no stale ownership.
    ball_owner_.reset();
    // Slice 26.3: also disarm the kick-alive counter so a hypothetical
    // post-end resume doesn't inherit a stale skip-rest-snap window.
    kick_alive_ticks_remaining_ = 0;
}

std::vector<Match::PendingGoal> Match::drainPendingGoals()
{
    // Move-and-clear in one step. Reserves nothing on the returned
    // vector — the SimServer caller iterates once and discards.
    std::vector<PendingGoal> drained;
    drained.swap(pending_goals_);
    return drained;
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

    // Slice 16.3: surface current ball ownership so the wire trailer
    // can carry it to clients (used by Slice 16.5 for the owner ring).
    snap.ball_owner = ball_owner_;

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
