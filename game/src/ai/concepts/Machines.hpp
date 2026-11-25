// game/src/ai/concepts/Machines.hpp
//
// THE CONCEPT MACHINES — a player's brain as machines running side by side.
//
// Owner 2026-11-25: "formation is one state, man marking or zonal is another state machine?
// then under each there needs to be a state machine for diff concepts and maybe multi state
// machines? like cover shadow or not. maybe there is no cover shadow to do" · "wouldn't it be
// better ai coding to use state machines" · "can we allow for temp 'extra' state machine …
// they would complement or fight each other but run" · "ok yes like it" · "commit and push
// then start the engine machines". The design: docs/taxonomy-one-system.md, "Player brain as
// parallel machines".
//
// Every player has, beside his job state (ai/Players), one machine per concept. Each is in
// exactly one state; state 0 is always ASLEEP — "nothing to do" — and most of the time that is
// where it is. Several can be awake at once. Each tick:
//
//   update     every machine reads the situation (his job, the team's ball, the reads — direct
//              opponent, reach, shadows) and moves to its state. A machine that woke up stays
//              awake at least hold_ticks (commitment), unless what it lives in has gone.
//   resolve    after his job state has given its orders, the awake machines' PROPOSALS are
//              applied in priority order. Today all are BENDS: they move the target his job gave
//              him and leave his job in charge (the cover shadow bends the press onto a lane;
//              pressing distance bends his place toward his man). A machine that REPLACES the
//              job's orders, and a rule for two that fight, come with the first such machine.
//
// The first three, built here:
//
//   marking scheme     asleep (his team has the ball, or a keeper) · watching his man (a
//                      direct opponent, not tight) · zonal on #x (marking him goal-side in his
//                      zone) · free (no man: the spare man, the +1). A recognition with memory:
//                      it proposes nothing yet — the job state "mark his man" still does it.
//   cover shadow       asleep (nobody behind him) · hiding (someone is in his shadow just from
//                      where he stands — passive) · pressing on the lane (he is the presser
//                      and bends his approach onto the line to the receiver he hides;
//                      physics.shadow.press above 0 only).
//   pressing distance  asleep · on (defending, he has a man — the whole time) · stepping into reach
//                      (holding his place, his man out of reach: bends his place toward him;
//                      physics.pressdist.hold above 0 only).
//
// With no dial rows nothing bends and the sim is the sim it was (the goldens prove it).
// Fixed point, no noise: the same world gives the same machines.

#pragma once

#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>

namespace fh::game::ai::concepts {

// The machines, by wire number (game_engine_terms kind 'machine', wire_index).
enum class MachineId : std::uint8_t { Marking = 1, CoverShadow = 2, PressingDistance = 3,
                                      Recover = 4, Press = 5, LooseBall = 6, DoubleTeam = 7, Cover = 8 };
inline constexpr int kMachineCount = 8;
inline constexpr std::uint8_t kAsleep = 0;

// The order they win in when two awake machines want things that cannot both happen — the copy
// row machine_order (mig 1882, the owner's to change; the viewer reads the row): recover › press ›
// loose ball › double-team › marking › cover shadow › cover › pressing distance › (his place).
inline constexpr MachineId kPriority[kMachineCount] = {
    MachineId::Recover, MachineId::Press, MachineId::LooseBall, MachineId::DoubleTeam,
    MachineId::Marking, MachineId::CoverShadow, MachineId::Cover, MachineId::PressingDistance};
constexpr int rankOf(MachineId m) {
    for (int i = 0; i < kMachineCount; ++i) if (kPriority[i] == m) return i;
    return kMachineCount;
}
// A machine that TAKES his spot (its proposal replaces the job's target, it does not bend it).
// Recover first (11/25); press, loose ball and double-team are still the job states themselves.
constexpr bool takesSpot(MachineId m) { return m == MachineId::Recover; }

namespace marking { enum : std::uint8_t { Asleep = 0, Watching = 1, Zonal = 2, Free = 3 }; }
namespace shadow { enum : std::uint8_t { Asleep = 0, Hiding = 1, OnTheLane = 2 }; }
// Owner 11/25: "how is the concept not in the state the whole time? when they don't have ball and
// defending … is it a state or not". It is: ON whenever his side defends and he has a man (not the
// presser, not the loose ball's man); STEPPING is the part where he corrects (dial above 0 only).
namespace pdist { enum : std::uint8_t { Asleep = 0, On = 1, Stepping = 2 }; }
// 11/25, the second five: each awake while the engine is doing that thing (recognitions; they
// propose nothing yet — the job states execute). They make the whole brain one set of machines
// the page reads, instead of the page guessing from the job.
namespace recover { enum : std::uint8_t { Asleep = 0, GettingBack = 1 }; }
namespace press { enum : std::uint8_t { Asleep = 0, Closing = 1 }; }
namespace looseball { enum : std::uint8_t { Asleep = 0, Going = 1 }; }
namespace doubleteam { enum : std::uint8_t { Asleep = 0, SecondMan = 1 }; }
namespace cover { enum : std::uint8_t { Asleep = 0, Behind = 1 }; }

// What his job state is, as far as the machines care.
enum class Job : std::uint8_t { Other, Hold, Press, Mark, Keeper, Chase, DoubleTeam };

// One tick's situation for one player — everything the machines read, gathered by the Brain.
struct MachineSense {
    Job job = Job::Other;
    bool their_ball = false;         // his side is defending (a defending phase)
    int direct = -1;                 // his direct opponent (DirectOpponents), -1 none
    int mark = -1;                   // the man the block has him marking, -1 none
    std::uint32_t hidden = 0;        // a bit per opponent slot in his shadow
    int screen = -1;                 // the receiver his side's presser should hide, -1 none
    math::Vec2 step{};               // pressing distance: the step back into reach (zero = in reach)
    math::Fixed64 shadow_press{};    // dials (0 = off)
    math::Fixed64 press_hold{};
    bool behind = false;             // his place is recover_m+ goal-side of him: the line is broken behind him
    bool cover = false;              // he is the deeper centre-back behind the one who steps
    int carrier = -1;                // their man on the ball, -1 none
};

struct MachineState {
    std::uint8_t state = kAsleep;
    std::int16_t other = -1;         // the man it is about (his man / the receiver), -1 none
    std::uint64_t since = 0;         // tick it entered this state
};

struct MachineParams {
    std::uint64_t hold_ticks = 9;    // an awake machine stays awake at least this long (0.3 s): no flicker
};

class PlayerMachines {
public:
    // Every machine of one player, one tick.
    void update(core::SlotIndex slot, const MachineSense& s, std::uint64_t tick);
    // After his job state's orders: the awake machines' proposals on his target. `carrier` is
    // where the man he presses stands (the press's stand-off is measured from him), `standoff`
    // that distance; `receiver` the man he hides. Returns true if anything moved the target.
    bool bendPress(core::SlotIndex slot, math::Vec2 carrier, math::Fixed64 standoff, math::Vec2 receiver,
                   math::Fixed64 dial, math::Vec2& target) const;
    bool bendHold(core::SlotIndex slot, math::Vec2 step, math::Fixed64 dial, math::Vec2& target) const;
    // The resolver: the highest-ranked awake machine that takes his spot, or none (driving = false).
    // A lower machine's bend of that spot is dropped — they fight and the order decides; a bend of a
    // job's own target (the cover shadow on the press) still applies — they complement.
    MachineId driver(core::SlotIndex slot, bool& driving) const;
    bool outranked(core::SlotIndex slot, MachineId m) const;
    // Recover's proposal while he holds his place: straight to his place in the shape (the job's
    // target), and nothing below it bends it. Returns true when it drives.
    bool recoverTo(core::SlotIndex slot, math::Vec2 place, math::Vec2& target) const;

    const MachineState& of(core::SlotIndex slot, MachineId m) const { return st_[slot & 31][static_cast<int>(m) - 1]; }
    bool awake(core::SlotIndex slot, MachineId m) const { return of(slot, m).state != kAsleep; }
    void reset() { for (auto& p : st_) for (auto& m : p) m = MachineState{}; }
    const MachineParams& params() const { return p_; }

private:
    void set(MachineState& m, std::uint8_t state, std::int16_t other, std::uint64_t tick, bool may_leave);
    MachineParams p_{};
    std::array<std::array<MachineState, kMachineCount>, 32> st_{};
};

}  // namespace fh::game::ai::concepts
