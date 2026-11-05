// game/src/ai/Orders.hpp — what a brain tells one player this tick, and why
// (the overlay's vocabulary). Split out of Brain.hpp (G5.22) so the player
// states can build orders without the Brain.
#pragma once

#include "core/Intent.hpp"
#include "core/World.hpp"
#include "math/Vec3.hpp"

#include <cstdint>

namespace fh::game::ai {

// WHY a player did what he did (G4.41, the brain overlay — James: "an
// overlay that shows info about players brain … buckland does basically
// this", after [Buckland]'s Simple Soccer debug view). Read-only: the sim
// never looks at it, so it can't move a golden. Names = kWhyNames, sent to
// clients in the BRAIN_LEGEND frame.
enum class Why : std::uint8_t {
    Hold, Shoot, Pass, PassLadder, OverTop, Recycle, KeeperPunt, Dribble, Clear,
    KeeperSweep, KeeperPosition, CoverShadow, CounterPress, Tackle, Recover,
    Press, Chase, Delay, Libero, Mark, GiveAndGo, BlindSideRun, RunInBehind,
    Outlet, Support, Human, WaitForRunner, LapseDeep, LapseStepOut,
    LapseShort, LapseLong, HabitShort, HabitLong, HabitDeep, HabitStepOut,
    MeetPass, KeepRunning, KeeperDive, SideOn, DropStep, Unmark, PlayBack, Shield,
    JumpPass, ShadowHelp, PackMiddle, PressFullBack, LockDoor,
    Intercept, NoTurn, Contain, ShadowLine, PlayOff,
    MarkTight, ProtectMiddle, AttackDrop, RunBackDrop, CallShadow,
    CallManOn, CallTurn, CallTime, CallSqueeze, CallLine,
    HurryKeeper, PressBadTouch, OverHighLine, KeeperShort,
    FalseNineDrop, Overlap, ComeShort, CheckIn,
    WaitPass, StayOnside, TrackRunner, DoubleCheckIn, PreventiveMark, PopOut, Settle,
    TakeRestart, ThrowIn, CornerKick, LawDistance,
    Cross, AttackBox,
};
inline constexpr const char* kWhyNames[] = {
    "hold shape", "shoot", "pass", "pass ladder", "over the top", "recycle", "keeper punt", "dribble", "clear",
    "keeper sweep", "keeper position", "cover shadow", "counter-press", "tackle", "recover goal-side",
    "press", "chase ball", "delay", "libero", "mark", "give and go", "blind-side run", "run in behind",
    "outlet", "support", "human", "wait for the runner",
    "lapse: sweeping too deep", "lapse: stepped out too high",
    "lapse: short and simple", "lapse: hit it long",
    "likes it short", "likes it long", "likes to sit deep", "likes to step out",
    "meet the pass", "keep running", "keeper dive", "jockey side-on", "turn and run with him",
    "lose your marker", "play it back", "shield and turn",
    "jump the pass", "shadow and help", "pack the middle", "press the full-back", "lock the door",
    "intercept", "no turn", "contain", "shadow the line", "play off for the long ball",
    "mark tight (near the ball)", "protect the middle (far from the ball)",
    "attack the ball in the air", "run back for the ball in the air",
    "call: adjust your shadow",
    "call: man on", "call: turn", "call: time", "call: squeeze", "call: line",
    "hurry the keeper", "press the bad touch",
    "over the high line", "keeper: short and simple",
    "false 9: drop in",
    "overlap", "winger: come short", "check in",
    "lapse: lets it come to him",
    "stay onside",
    "track the runner",
    "double the man checking in",
    "preventive marking", "pop out wide",
    "settle: walk it",
    "take the restart", "throw-in", "corner", "the law's distance",
    "cross", "attack the box",
};
inline constexpr int kWhyCount = static_cast<int>(sizeof(kWhyNames) / sizeof(kWhyNames[0]));

struct Orders {
    core::MoveIntent move;
    core::Action action = core::Action::None;
    // The overlay's read of the decision (never fed back into the sim).
    Why why = Why::Hold;
    math::Vec2 target{};          // where he's going / aiming
    std::int16_t other = -1;      // the pass receiver, marked man, pressed carrier
    std::uint8_t rung = 0;        // pass-ladder rung of a laddered pass (1-6)
    bool read = false;            // the passer read the interceptors for it (safe_pass, G4.86)
    // An aimed LoftedKick's first-bounce distance (G4.48); 0 = the preset
    // chip (clearances, punts).
    std::uint8_t carry_m = 0;
    // G4.95: hit it first time, no control touch (a clearance).
    bool first_time = false;
    // A kick played to a mate (G4.81): who (World ball().pass_to — the man
    // who meets it, the rest let it run); 0xFF = nobody. Filled with a
    // ground pass's weight (carry_m = metres to the target) in ordersFor.
    std::uint8_t pass_to = 0xFF;
    std::uint8_t passTo() const { return pass_to; }
    // What he could see (G4.66, overlay only): his picture of the men
    // behind him is this many tenths of a second old (0 = he just looked;
    // 255 = sees everything — the perfect band); `unseen` = how many men
    // he only knows from that look.
    std::uint8_t look_ds = 255;
    std::uint8_t unseen = 0;
    // A call he's making (G4.70-71, overlay + harness): what (a Why name),
    // to whom (-1 none, kBackLine = the back line); `due` = the call the
    // moment asked of him, said or not (Hold = none); `heard` = a call he
    // heard this tick (Hold = none).
    static constexpr std::int16_t kBackLine = 254;
    Why call = Why::Hold;
    std::int16_t call_to = -1;
    Why due = Why::Hold;
    Why heard = Why::Hold;
};

}  // namespace fh::game::ai
