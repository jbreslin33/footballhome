// game/src/ai/Brain.hpp
//
// First-generation team brain (G2.4): a deterministic, pure function of
// the World that produces one MoveIntent + Action per AI slot each tick.
// No RNG, no stored state beyond the static team setup — same world in,
// same orders out, on every architecture (DESIGN.md §3, §5).
//
// Behavior set ([FH] utility-lite; support-spot/role ideas trace to
// [Buckland] and [GRF]):
//   loose ball → each team's nearest player chases it; rest hold anchors
//   our ball   → AI carrier dribbles at the goal, shoots inside range;
//                teammates hold (ball-shifted) anchors = natural support
//   their ball → nearest player presses the carrier; rest hold anchors
// The three-layer architecture (team tactic → role → player utilities,
// DESIGN.md §5) grows out of exactly these hooks in later slices.

#pragma once

#include "ai/Concept.hpp"
#include "ai/Formation.hpp"
#include "core/World.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

struct TeamSetup {
    // team[slot] = 0 (home, attacks +x) or 1 (away, attacks -x).
    std::vector<std::uint8_t> team_of_slot;

    static TeamSetup splitHalves(std::uint8_t slot_count);
};

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
    MeetPass, KeepRunning,
};
inline constexpr const char* kWhyNames[] = {
    "hold shape", "shoot", "pass", "pass ladder", "over the top", "recycle", "keeper punt", "dribble", "clear",
    "keeper sweep", "keeper position", "cover shadow", "counter-press", "tackle", "recover goal-side",
    "press", "chase ball", "delay", "libero", "mark", "give and go", "blind-side run", "run in behind",
    "outlet", "support", "human", "wait for the runner",
    "lapse: sweeping too deep", "lapse: stepped out too high",
    "lapse: short and simple", "lapse: hit it long",
    "likes it short", "likes it long", "likes to sit deep", "likes to step out",
    "meet the pass", "keep running",
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
    // An aimed LoftedKick's first-bounce distance (G4.48); 0 = the preset
    // chip (clearances, punts).
    std::uint8_t carry_m = 0;
};

class Brain {
public:
    // Formation specs per team; an invalid/empty spec falls back to the
    // built-in for that team's size (tests and DB-down boots take this
    // path, so goldens never depend on the database).
    Brain(TeamSetup setup, math::Fixed64 pitch_half_x,
          math::Fixed64 pitch_half_y,
          FormationSpec home = {}, FormationSpec away = {});

    // Skill noise (G4.3): perception delay + decision jitter per team.
    // Defaults (zero) = the perfect-play baseline the goldens lock.
    // G4.33: the class-based concepts read their numbers from the club DB
    // (game_model_params); without it they keep their seeded defaults.
    void setModelParams(const core::ModelParams& p) {
        book_.configure(p);
        initiative_ = p.fixed("skill.tendency.initiative", 1000);
    }

    // Per-player level (G4.30): the band bent by the player's attributes.
    void setSlotLevel(core::SlotIndex slot, const core::LevelParams& lv) {
        if (slot_level_.size() <= slot) {
            slot_level_.resize(slot + 1u);
            slot_level_set_.resize(slot + 1u, 0);
        }
        slot_level_[slot] = lv;
        slot_level_set_[slot] = 1;
    }
    const core::LevelParams& levelOf(core::SlotIndex slot) const {
        return slot < slot_level_set_.size() && slot_level_set_[slot]
                   ? slot_level_[slot]
                   : level_[setup_.team_of_slot[slot]];
    }

    void setLevels(const core::LevelParams& home,
                   const core::LevelParams& away,
                   std::uint64_t match_seed) {
        level_[0] = home;
        level_[1] = away;
        match_seed_ = match_seed;
        // Reset every slot's knowledge to its band's default ratings.
        for (std::size_t i = 0; i < ratings_.size(); ++i) {
            ratings_[i] = core::defaultRatings(
                level_[setup_.team_of_slot[i]]);
        }
    }

    // Per-slot graded knowledge (game/CONCEPTS.md; 0-100 per concept).
    void setRatings(core::SlotIndex slot, const core::ConceptRatings& r) {
        if (slot < ratings_.size()) ratings_[slot] = r;
    }
    // What he KNOWS (ability, before the game model's demand): his habits —
    // a lapse picks the neighbour concept he's best at (G4.46).
    void setHabits(core::SlotIndex slot, const core::ConceptRatings& r) {
        if (habits_.size() <= slot) habits_.resize(slot + 1u, core::ConceptRatings{});
        habits_[slot] = r;
    }
    // His TENDENCIES (G4.47, mig 669; -1 = none): how much he LIKES a
    // concept, apart from how well he does it — weights his lapses and
    // makes him try a liked neighbour on his own initiative.
    void setTendencies(core::SlotIndex slot, const core::PresetOverlay& t) {
        if (tendencies_.size() <= slot) {
            core::PresetOverlay none;
            none.fill(-1);
            tendencies_.resize(slot + 1u, none);
        }
        tendencies_[slot] = t;
    }
    const core::ConceptRatings& ratings(core::SlotIndex slot) const {
        return ratings_[slot];
    }

    // Orders for ONE slot given the current world. Pure + deterministic.
    Orders ordersFor(core::SlotIndex slot, const core::World& world) const;

    // The flight read (G4.49): for a free live ball, where and when each
    // player can first take it — the ball's own path walked tick by tick
    // (gravity, bounces, skid, roll), a touch only where it's low and slow
    // enough to control. A pure function of the world; cached per tick
    // because all 22 brains ask the same question.
    struct FlightRead {
        bool live = false;                 // a free ball in play
        std::vector<std::int16_t> tick;    // ticks until slot can take it; -1 = can't (horizon)
        std::vector<math::Vec2> at;        // where
        int first[2] = {-1, -1};           // each team's first man to it
    };
    const FlightRead& flightRead(const core::World& world) const;

private:
    int attackSign(core::SlotIndex slot) const {
        return setup_.team_of_slot[slot] == 0 ? +1 : -1;
    }
    // Is `slot` its team's closest player to `target` (ties → lower slot)?
    bool isTeamClosest(core::SlotIndex slot, const core::World& world,
                       const math::Vec3& target) const;
    // How many teammates are strictly closer to `target` (0 = I am
    // closest, 1 = I am the cover man, ...).
    int teamCloserCount(core::SlotIndex slot, const core::World& world,
                        const math::Vec3& target) const;

    TeamSetup setup_;
    math::Fixed64 half_x_, half_y_;
    FormationSpec spec_[2];
    core::LevelParams level_[2];
    ConceptBook book_;   // G4.33 class-based concepts
    // G4.30 per-player levels (perception, decisions, keeper reaction);
    // empty / unset = the team band.
    std::vector<core::LevelParams>  slot_level_;
    std::vector<std::uint8_t>       slot_level_set_;
    std::uint64_t match_seed_ = 0;
    std::vector<core::ConceptRatings> ratings_;
    std::vector<core::ConceptRatings> habits_;
    std::vector<core::PresetOverlay> tendencies_;
    mutable FlightRead flight_;
    mutable std::uint64_t flight_tick_ = ~std::uint64_t{0};
    mutable std::int64_t flight_key_[3] = {0, 0, 0};
    math::Fixed64 initiative_ = math::Fixed64::one();
    // Graded application: does slot APPLY concept (bit index) this tick?
    // Consistency roll — deterministic noise vs the rating.
    bool applies(core::SlotIndex slot, int concept_idx,
                 std::uint64_t tick) const {
        const std::uint8_t r = ratings_[slot][concept_idx];
        if (r == 0) return false;
        if (r >= 100) return true;
        const auto n = core::detNoise(match_seed_, tick, slot,
                                      static_cast<std::uint8_t>(32 + concept_idx));
        return (n + math::Fixed64::one()) <
               math::Fixed64::fromFraction(r, 50);
    }
    int tendency(core::SlotIndex slot, int c) const {
        return slot < tendencies_.size() ? tendencies_[slot][c] : -1;
    }
    // The concept slot lapses into when his roll on concept_idx fails
    // (G4.46): one of its 'lapses-to' neighbours, weighted by his tendency
    // on each when he has one, else his ability (habit); -1 = none.
    int lapse(core::SlotIndex slot, int concept_idx, std::uint64_t window) const {
        if (slot >= habits_.size()) return -1;
        auto weight = [&](int to) {
            const int t = tendency(slot, to);
            return t >= 0 ? t : static_cast<int>(habits_[slot][to]);
        };
        int total = 0;
        for (int to : core::concepts().lapses(concept_idx)) total += weight(to);
        if (total <= 0) return -1;
        const auto n = core::detNoise(match_seed_, window, slot, static_cast<std::uint8_t>(240));
        // n in [-1, 1) → a pick in [0, total).
        int pick = static_cast<int>((((n + math::Fixed64::one()) * total) / 2).raw >>
                                    math::Fixed64::FRAC_BITS);
        for (int to : core::concepts().lapses(concept_idx)) {
            pick -= weight(to);
            if (pick < 0) return to;
        }
        return -1;
    }
    // What slot actually plays for concept_idx this window (G4.47):
    //   1. a neighbour he LIKES (tendency t > 50) on his own initiative,
    //      (t − 50)% of windows × tendency.initiative — "tries long balls";
    //   2. else the concept itself, when his model asks and his ability
    //      roll succeeds;
    //   3. else, when asked, a lapse into a neighbour;
    //   -1 = none of it (the generic brain).
    int choose(core::SlotIndex slot, int concept_idx, std::uint64_t window) const {
        int k = 0;
        for (int to : core::concepts().lapses(concept_idx)) {
            const int t = tendency(slot, to);
            ++k;
            if (t <= 50) continue;
            const auto n = core::detNoise(match_seed_, window, slot, static_cast<std::uint8_t>(240 + k));
            if ((n + math::Fixed64::one()) * 50 < math::Fixed64::fromInt(t - 50) * initiative_)
                return to;
        }
        if (ratings_[slot][concept_idx] == 0) return -1;
        if (applies(slot, concept_idx, window)) return concept_idx;
        return lapse(slot, concept_idx, window);
    }
    // counter_attack (bit 23, G4.18): is slot's team inside its fast-break
    // window — ball won from the opponent IN OUR OWN HALF, within
    // 2 s + rating ticks? A rebound recovered in their box is a
    // scramble, not a transition (measured: those wins sit 0.6 s
    // before the goal and doubled world scoring when they counted).
    bool inCounterWindow(core::SlotIndex slot,
                         const core::World& world) const {
        const std::uint8_t r = ratings_[slot][23];
        const std::uint8_t team = setup_.team_of_slot[slot];
        if (r == 0 || world.lastLosingTeam() == 0xFF ||
            world.lastLosingTeam() == team)
            return false;
        if (world.tickCount() - world.turnoverTick() >=
            60 + static_cast<std::uint64_t>(r))
            return false;
        const math::Fixed64 x = world.turnoverBallX();
        return team == 0 ? x.raw < 0 : x.raw > 0;
    }
    // Magnitude helper: rating as a 0..1 Fixed64.
    math::Fixed64 degree(core::SlotIndex slot, int concept_idx) const {
        return math::Fixed64::fromFraction(ratings_[slot][concept_idx], 100);
    }
    // Per-slot index within its own team (formation base lookup).
    std::vector<std::uint8_t> index_in_team_;
    std::vector<std::uint8_t> team_size_;
};

}  // namespace fh::game::ai
