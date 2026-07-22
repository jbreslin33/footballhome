// footballhome sim - OneVsOneAttackDefendScenario implementation

#include "scenario/OneVsOneAttackDefendScenario.hpp"

#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "math/FixedMath.hpp"

namespace fh::sim::scenario {

namespace {

bool contains(const GoalRegion& region, const math::Vec3& point)
{
    return point.x >= region.min.x && point.x <= region.max.x
        && point.y >= region.min.y && point.y <= region.max.y
        && point.z >= region.min.z && point.z <= region.max.z;
}

} // namespace

OneVsOneAttackDefendScenario::OneVsOneAttackDefendScenario(
    std::optional<PersonId> defender_profile_source) noexcept
{
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    ball_.position = math::Vec3{math::Fixed64::fromInt(-15),
                                math::Fixed64::zero(),
                                math::Fixed64::zero()};
    ball_.velocity = math::Vec3{};

    SlotSpawn attacker;
    attacker.slot     = SlotId{1};
    attacker.position = math::Vec3{math::Fixed64::fromInt(-15),
                                   math::Fixed64::zero(),
                                   math::Fixed64::zero()};
    attacker.heading  = math::Fixed64::zero();
    attacker.role     = Role::ST9;
    spawns_.push_back(attacker);

    SlotSpawn defender;
    defender.slot     = SlotId{2};
    defender.position = math::Vec3{math::Fixed64::fromInt(10),
                                   math::Fixed64::zero(),
                                   math::Fixed64::zero()};
    defender.heading  = math::FX_PI;
    defender.role     = Role::LCB;
    defender.ai_profile_source = defender_profile_source;
    defender.mark_target = SlotId{1};
    spawns_.push_back(defender);

    const auto half_length     = math::Fixed64::fromFraction(105, 2);
    const auto goal_depth      = math::Fixed64::fromInt(2);
    const auto goal_half_width = math::Fixed64::fromFraction(732, 200);
    const auto goal_height     = math::Fixed64::fromFraction(244, 100);
    const auto z_floor         = math::Fixed64::zero();
    const auto neg_half_width  = math::Fixed64::zero() - goal_half_width;
    const auto neg_half_length = math::Fixed64::zero() - half_length;

    GoalRegion west;
    west.index = 0;
    west.min   = math::Vec3{neg_half_length - goal_depth,
                            neg_half_width,
                            z_floor};
    west.max   = math::Vec3{neg_half_length,
                            goal_half_width,
                            goal_height};
    goal_regions_.push_back(west);

    GoalRegion east;
    east.index = 1;
    east.min   = math::Vec3{half_length,
                            neg_half_width,
                            z_floor};
    east.max   = math::Vec3{half_length + goal_depth,
                            goal_half_width,
                            goal_height};
    goal_regions_.push_back(east);
}

bool OneVsOneAttackDefendScenario::checkSuccess(
    const awareness::WorldView& w) const
{
    return ballInEastGoal(w);
}

bool OneVsOneAttackDefendScenario::checkReset(
    const awareness::WorldView& w) const
{
    if (w.time_seconds >= math::Fixed64::fromInt(20)) {
        return true;
    }

    if (!w.ball_owner.has_value()) {
        return false;
    }

    const auto defender_slot = SlotId{2};
    if (*w.ball_owner != defender_slot) {
        return false;
    }

    const auto defender_possession_seconds = math::Fixed64::fromFraction(3, 1);
    return w.time_seconds >= defender_possession_seconds;
}

std::vector<std::string> OneVsOneAttackDefendScenario::hints() const
{
    return {
        "Beat the defender and carry the ball into the east goal.",
        "Slot 1 starts on the ball 15 m west of centre facing east.",
        "Slot 2 starts 10 m east of centre as an AI defender.",
        "The run resets after 20 seconds.",
    };
}

UnclaimedControllerKind OneVsOneAttackDefendScenario::unclaimedControllerFor(
    SlotId slot) const
{
    return (slot == SlotId{2}) ? UnclaimedControllerKind::Defender
                               : UnclaimedControllerKind::Idle;
}

void OneVsOneAttackDefendScenario::applyConceptOverrides(
    SlotId slot,
    profile::ConceptSet& concepts) const
{
    if (slot == SlotId{2}) {
        concepts.plug(m0::kPressing, math::Fixed64::one());
        concepts.plug(m0::kJockey, math::Fixed64::one());
        concepts.plug(m0::kMarking, math::Fixed64::one());
    }
}

bool OneVsOneAttackDefendScenario::ballInEastGoal(
    const awareness::WorldView& w) const
{
    if (!w.ball.has_value() || goal_regions_.size() < 2u) {
        return false;
    }
    for (const auto& entity : w.entities) {
        if (entity.id == *w.ball) {
            return contains(goal_regions_[1], entity.position);
        }
    }
    return false;
}

} // namespace fh::sim::scenario