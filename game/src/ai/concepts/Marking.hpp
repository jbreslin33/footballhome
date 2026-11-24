// game/src/ai/concepts/Marking.hpp
//
// MARKING as one concept, built the way the taxonomy says a concept is built (owner
// 2026-11-24, docs/taxonomy-one-system.md): RECOGNISE → CHOOSE → EXECUTE, each its own
// thing, each visible.
//
//   recognise   EYES — a small machine of its own: he looks at the ball, checks his man,
//               or opens up to see both. What he sees goes into his MEMORY with the tick
//               he saw it; what he has not seen he does not know. A run made on his blind
//               side is acted on late, or not at all — the fork he did not see.
//   choose      every STEP of marking whose cue is true in his memory is scored; the best
//               one, once it has held for his reaction time, becomes his state. The list
//               and the scores are kept so a viewer can read why.
//   execute     the step's own spot and pace.
//
// The states, as a stack:   Marking  ›  kind  ›  step
//   kind  (inheritance: the same steps, one rule different)
//     ManOriented   his man, anywhere                       game_concepts man-mark
//     Zonal         his man while he is in his zone;        game_concepts zonal-marking
//                   he leaves it → pass him on
//   step  (each a catalogue concept; the behaviour code is in behaviours.list)
//     PickUp         find-your-man          get to him
//     Position       mark-position          goal-side; ball-side and tighter the nearer the
//                    near-tight-far-zone    ball and the nearer our goal
//                    tighten-near-goal
//     TrackRunner    track-the-runner       he runs at our goal: go with him, goal-side of
//                                           where he is going
//     FollowDropper  follow-the-dropper     he drops off: follow him in (man-oriented only)
//     PassOn         direct-opponent        he left the zone: let him go (zonal only)
//     JumpPass       jump-the-pass          the pass is on its way to him: go as it goes
//     NoTurn         defend-your-man        he has it, back to goal: tight, don't dive in
//     Contain        defend-your-man        he has turned: stand off, contain
//
// A CAPABILITY the engine can use, its usage set by data (owner 11/24: "it exists … and can
// be used to more realistically accomplish the goal of the sim"). Two callers:
//   • the sim's own marking — DefendingBlock's MarkMan runs it on the man assignMarks gave
//     him when game_model_params has physics.mark.mind = 1. No row = off: the marking fitted
//     to tracking data, unchanged. The harness decides (fh-game-match GAME_PARAMS).
//   • the teaching room (src/teach), for every man whose plan job is a mark.
// Fixed point throughout, no noise: the same world gives the same mind.
//
// The priorities and distances here are [FH] coaching values, not fitted — they are the
// numbers data should set when a side's use of each step is measured.

#pragma once

#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>

namespace fh::game::ai::concepts {

enum class MarkKind : std::uint8_t { ManOriented, Zonal };
enum class MarkStep : std::uint8_t { PickUp, Position, TrackRunner, FollowDropper, PassOn, JumpPass, NoTurn, Contain };
inline constexpr int kMarkStepCount = 8;
enum class Eyes : std::uint8_t { Ball, Man, Both };

// The behaviour code of each state (src/ai/behaviours.list, game_engine_behaviours).
inline constexpr const char* kMarkStepCodes[kMarkStepCount] = {
    "mark_pick_up", "mark_position", "mark_track_runner", "mark_follow_dropper",
    "mark_pass_on", "mark_jump_pass", "mark_no_turn", "mark_contain"};
inline constexpr const char* kMarkKindCodes[2] = {"mark_kind_man", "mark_kind_zonal"};
inline constexpr const char* kEyesCodes[3] = {"eyes_ball", "eyes_man", "eyes_both"};

struct MarkParams {
    using F = math::Fixed64;
    // Eyes.
    F fov_cos = F::fromFraction(-17, 100);       // half field of view ~100°: seen if cos(angle off his gaze) is above this
    F both_cos = F::fromFraction(-34, 100);      // ball and man under ~110° apart: he can open up and see both
    F feel_m = F::fromInt(2);                    // touch-tight he knows where his man is without looking
    std::int32_t scan_every = 36;                // ticks between checks of his man (1.2 s at 30 Hz)
    std::int32_t scan_for = 9;                   // ticks a check takes (0.3 s)
    std::int32_t react = 8;                      // ticks a new answer must hold before he acts on it (~0.27 s)
    // Position.
    F tight_near = F::fromInt(1);                // metres off his man, the ball near
    F tight_far = F::fromInt(4);                 // … the ball far
    F ball_near_m = F::fromInt(10), ball_far_m = F::fromInt(40);
    F goal_tight_m = F::fromInt(20);             // inside this of our goal he closes toward tight_box
    F tight_box = F::fromFraction(7, 10);
    F ball_side_near = F::fromFraction(1, 2);    // how far round to the ball's side he stands: ball near … far
    F ball_side_far = F::fromFraction(3, 20);
    // The cues.
    F pick_m = F::fromInt(6);                    // further than this off his spot: he is still picking him up
    F run_mps = F::fromFraction(7, 2);           // his man moving at our goal this fast is a run
    F drop_mps = F::fromFraction(5, 2);          // … away from it this fast is dropping off
    F zone_r = F::fromInt(14);                   // zonal: his man is his within this of his own spot
    F lead_s = F::fromFraction(3, 5);            // tracking: goal-side of where his man will be in this long
    F noturn_m = F::fromFraction(4, 5);
    F contain_m = F::fromFraction(5, 2);
};

// One thing he knows, and when he last saw it.
struct Seen {
    math::Vec2 pos{}, vel{};
    std::uint64_t tick = 0;
    bool ever = false;
};

struct MarkMemory {
    Seen man, ball;
    bool man_has_ball = false;      // as he last saw it
    bool man_back_to_goal = false;  // on the ball, facing away from our goal
    bool pass_to_man = false;       // a pass is on its way to his man
};

struct MarkOption {
    MarkStep step = MarkStep::Position;
    bool cue = false;               // true in his memory
    std::int16_t score = 0;         // 0 when the cue is not true
};

// What one tick of the mind gives back: his orders, and everything a viewer reads.
struct MarkView {
    math::Vec2 target{}, face{};
    bool full_pace = false;
    MarkKind kind = MarkKind::ManOriented;
    MarkStep step = MarkStep::Position;      // the state he is in
    MarkStep wants = MarkStep::Position;     // the best answer right now (differs while he reacts)
    Eyes eyes = Eyes::Ball;
    bool sees_man = false, sees_ball = false;
    std::array<MarkOption, kMarkStepCount> options{};
};

class MarkingMind {
public:
    MarkingMind() = default;
    MarkingMind(MarkKind kind, core::SlotIndex man, math::Vec2 home) : kind_{kind}, man_{man}, home_{home} {}

    core::SlotIndex man() const noexcept { return man_; }
    MarkKind kind() const noexcept { return kind_; }
    void setHome(math::Vec2 h) noexcept { home_ = h; }
    const MarkMemory& memory() const noexcept { return mem_; }
    const MarkParams& params() const noexcept { return p_; }

    // One tick for `slot`, whose side defends the goal at x = -sg × half-length.
    MarkView think(const core::World& w, core::SlotIndex slot, math::Fixed64 sg);

private:
    Eyes look(const core::World& w, core::SlotIndex slot, math::Vec2& gaze);
    void see(const core::World& w, core::SlotIndex slot, math::Fixed64 sg, MarkView& out);
    math::Vec2 spot(math::Vec2 goal) const;

    MarkParams p_{};
    MarkKind kind_ = MarkKind::ManOriented;
    core::SlotIndex man_ = 0;
    math::Vec2 home_{};
    MarkMemory mem_{};
    math::Vec2 gaze_{math::Fixed64::one(), math::Fixed64::zero()};
    MarkStep step_ = MarkStep::PickUp;
    MarkStep pending_ = MarkStep::PickUp;
    std::uint64_t pending_since_ = 0;
    bool started_ = false;
};

}  // namespace fh::game::ai::concepts
