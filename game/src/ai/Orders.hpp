// game/src/ai/Orders.hpp — what a brain tells one player this tick, and why
// (the overlay's vocabulary). Split out of Brain.hpp (G5.22) so the player
// states can build orders without the Brain.
#pragma once

#include "core/Intent.hpp"
#include "core/World.hpp"
#include "math/Vec3.hpp"

#include <cstdint>

namespace fh::game::ai {

// WHY a player did what he did (G4.41, the brain overlay, after [Buckland]'s
// Simple Soccer debug view). Read-only: the sim never looks at it. Names =
// kWhyNames, sent to clients in the BRAIN_LEGEND frame. G5.23: only what the
// clean player states and restarts decide.
enum class Why : std::uint8_t {
    Hold, Shoot, Pass, Cross, Dribble, Clear, KeeperPunt, KeeperPosition, KeeperDive,
    Press, Chase, MeetPass, Human, TakeRestart, ThrowIn, CornerKick, LawDistance, AttackBox, InBehind, RunLine, IntoSpace, Mark,
};
inline constexpr const char* kWhyNames[] = {
    "hold shape", "shoot", "pass", "cross", "dribble", "clear", "keeper punt", "keeper position", "keeper dive",
    "press", "chase ball", "meet the pass", "human", "take the restart", "throw-in", "corner", "the law's distance",
    "attack the box", "ball in behind", "run onto the line", "ball into space", "mark his man",
};
inline constexpr int kWhyCount = static_cast<int>(sizeof(kWhyNames) / sizeof(kWhyNames[0]));

// The trainer's label (docs/tactics-trainer.md step 1): which out-of-possession
// behaviour the engine is running for a man, by code. The codes are rows of
// game_engine_acts (mig 1199), which name the game_concepts row each one plays;
// the wording lives there, never here. Read-only: never fed back into the sim.
enum class Act : std::uint8_t { None, BlockSpot, BlockRecover, BlockCover, PressBall, ChaseBall, Mark };
inline constexpr const char* kActCodes[] = {"", "block_spot", "block_recover", "block_cover", "press_ball", "chase_ball", "block_mark"};
inline constexpr int kActCount = static_cast<int>(sizeof(kActCodes) / sizeof(kActCodes[0]));

struct Orders {
    core::MoveIntent move;
    core::Action action = core::Action::None;
    Why why = Why::Hold;          // the overlay's read (never fed back into the sim)
    math::Vec2 target{};          // where he's going / aiming
    math::Fixed64 aim_z{};        // G5.37: a shot's height where it crosses their line (0 = along the ground)
    std::int16_t other = -1;      // the pass receiver, pressed carrier
    // A loft's first-bounce distance; a ground pass's weight (metres to its target).
    std::uint8_t carry_m = 0;
    bool die = false;   // G5.57: a GroundKick that comes to rest carry_m away (the ball into space)
    bool first_time = false;      // G4.95: hit it first time, no control touch
    // A kick played to a mate (G4.81): who meets it; 0xFF = nobody.
    std::uint8_t pass_to = 0xFF;
    std::uint8_t passTo() const { return pass_to; }
};

}  // namespace fh::game::ai
